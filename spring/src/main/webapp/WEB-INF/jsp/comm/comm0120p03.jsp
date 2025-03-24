<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > null > 조직원관리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-10-19 13:36:12
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
    var auiGridMember;

    $(document).ready(function () {
        // AUIGrid 생성
        createAUIGridMember();
        goSearch();
    });
    
    function createAUIGridMember() {
        var gridPros = {
            rowIdField: "_$uid",
            editable: false,
            // 체크박스 표시 설정
            showRowCheckColumn: true,
            // 전체 체크박스 표시 설정
            showRowAllCheckBox: true,
            // 전체 선택 체크박스가 독립적인 역할을 할지 여부
            independentAllCheckBox: true,
            // 체크박스 설정
            rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
                if (item.have_group_yn == 'Y') { // 그룹이 있으면 체크 enable
                    return false;
                }
                return true;
            },
            // 스타일 설정
            rowStyleFunction: function (rowIndex, item) {
                if (item.have_group_yn == 'Y') { // 그룹이 있으면 회색 바탕
                    return "aui-status-complete";
                }
            }
        };

        // 생성 될 칼럼 레이아웃
        var columnLayout = [
            {
                dataField: "have_group_yn",
                visible: false
            },
            {
                dataField: "mem_no",
                visible: false
            },
            {
                dataField: "job_grp_cd",
                visible: false
            },
            {
                dataField: "job_grp_name",
                headerText: "그룹명",
            },
            {
                dataField: "org_name",
                headerText: "부서",
            },
            {
                dataField: "mem_name",
                headerText: "직원명",
            },
            {
                dataField: "grade_name",
                headerText: "직책",
            },
            {
                dataField: "job_name",
                headerText: "직급",
            },
        ];

        // 그리드 생성
        auiGridMember = AUIGrid.create("#auiGridMember", columnLayout, gridPros);

        // 전체 선택 체크 박스 클릭 이벤트
        AUIGrid.bind(auiGridMember, "rowAllChkClick", auiRowAllChkClickHandlerMember);

        // 셀 더블 클릭 이벤트
        AUIGrid.bind(auiGridMember, "cellDoubleClick", auiCellDoubleClickHandlerMember);

    }    
    
    function auiCellDoubleClickHandlerMember(event) {
    	console.log(event);
        if (opener == null) { // 조직원 추가 팝업을 킨 상태에서 그룹설정 팝업을 닫았을 경우
            alert("팝업을 닫은 뒤 다시켜주세요.");
            return;
        }

        if (event.item.job_grp_cd == "") {
            opener.${inputParam.parent_js_name}(event.item, function () { // 조직원 추가 팝업을 킨 상태에서 그룹설정 팝업을 새로 고침했을 경우
                alert("그룹을 선택해주세요.");
            });
        }
    }
    
    
    function auiRowAllChkClickHandlerMember(event) {
        if (event.checked) { // 체크 상태
            AUIGrid.setCheckedRowsByValue(event.pid, "have_group_yn", "N"); // 그룹이 없는 데이터 모두 체크

        } else { // 체크 해제
            AUIGrid.setCheckedRowsByValue(event.pid, "have_group_yn", []);
        }
    }
    
    function fnClose() {
        window.close();
    }
    
    // 엔터키 이벤트
    function enter(fieldObj) {
        var field = ["s_kor_name"];
        $.each(field, function () {
            if (fieldObj.name == this) {
                goSearch();
            }
        });
    }
    
    // 체크 후 조직원 추가
    function goApply() {
        var checkItem = AUIGrid.getCheckedRowItemsAll(auiGridMember);
        if (checkItem != null) {
            opener.modifyMemberGridInfo(checkItem, function () {
                alert("그룹을 선택해주세요.");
                return;
            });
            window.close();
        }
    }
    
    function goSearch() {
		var param = {
                "s_job_grp_cd": $M.getValue("s_job_grp_cd"),
                "s_org_code": $M.getValue("s_org_code"),
                "s_kor_name": $M.getValue("s_kor_name"),
                "s_work_status_yn": $M.getValue("s_work_status_yn")
		};
			
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridMember, result.list);
				};
			}		
		);	
    }
	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
<div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
        <div class="search-wrap">
            <table class="table">
                <colgroup>
                    <col width="40px">
                    <col width="110px">
                    <col width="40px">
                    <col width="110px">
                    <col width="40px">
                    <col width="110px">
                    <col width="90px">
                    <col width="10px">
                    <col width="10px">
                </colgroup>
                <tbody>
                <tr>
                    <th>그룹명</th>
                    <td>
                        <select class="form-control" id="s_job_grp_cd" name="s_job_grp_cd">
                            <option value="">- 전체 -</option>
                            <c:forEach var="item" items="${codeMap['JOB_GRP']}">
                                <option value="${item.code_value}">${item.code_name}</option>
                            </c:forEach>
                        </select>
                    </td>
                    <th>부서</th>
                    <td>
                        <select class="form-control" id="s_org_code" name="s_org_code">
                            <option value="">- 전체 -</option>
                            <c:forEach var="item" items="${orgList}">
                                <option value="${item.org_code}">${item.org_name}</option>
                            </c:forEach>
                        </select>
                    </td>
                    <th>직원명</th>
                    <td>
                        <div class="icon-btn-cancel-wrap">
                            <input type="text" id="s_kor_name" name="s_kor_name" class="form-control">
                        </div>
                    </td>
                    <td class="pl10">
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" id="s_work_status_yn"
                                   name="s_work_status_yn" value="Y" checked="checked">
                            <label class="form-check-label" for="s_work_status_yn">퇴사자제외</label>
                        </div>
                    </td>
                    <td>
                        <button type="button" class="btn btn-important" style="width: 50px;"
                                onclick="javasctipt:goSearch();">조회
                        </button>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
        <!-- 직원 목록 -->
        <div class="title-wrap">
            <h4>직원목록</h4>
            <div class="right">
                <p class="text-warning">• 더블 클릭시 조직원 추가</p>
            </div>
        </div>
        <div id="auiGridMember" style="margin-top: 5px; height: 300px;"></div>
        <!-- /직원 목록 -->
        <!-- 버튼 영역 -->
        <div class="btn-group mt10 mr5">
            <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
            </div>
        </div>
        <!-- /버튼 영역 -->
    </div>
</div>
<!-- /팝업 -->
</body>
</html>