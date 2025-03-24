<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 경쟁사판매가공유 > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-22 19:33:02
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <style>
        /* 가격 변동된 셀 */
        .aui-right-red {
            text-align: right !important;
            vertical-align: middle !important;
            color : red;
        }
    </style>
	<script type="text/javascript">

        let auiGrid;

		$(document).ready(function() {
			createAUIGrid();
		});

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '경쟁사 판매가 공유');
		}

        // 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		}

        // 기종 및 메이커에 따른 모델 리스트 조회
        function goSearchMachine(msMakerCd) {

            const param = {
                s_ms_maker_cd : msMakerCd,
                s_ms_machine_type_cd : $M.getValue("s_ms_machine_type_cd"), // 기종
            };

            if (msMakerCd) {
                $M.goNextPageAjax(this_page + "/searchMachine", $M.toGetParam(param), {method : "GET", loader: true},
                    function(result) {
                        if (result.success) {
                            $("select#s_ms_mch_plant_seq option").remove();
                            $('#s_ms_mch_plant_seq').append('<option value="">' + "- 전체 -" + '</option>');

                            result.list.forEach(data => {
                                const value = data.ms_mch_plant_seq;
                                const text = data.ms_mch_name;
                                $('#s_ms_mch_plant_seq').append('<option value="' + value + '">' + text + '</option>');
                            });
                            goSearch();
                        }
                    }
                );
            } else {
                // 모델명 초기화
                $("select#s_ms_mch_plant_seq option").remove();
                $('#s_ms_mch_plant_seq').append('<option value="" >' + "- 전체 -" + '</option>');
            }
        }

        // 기종에 따른 메이커 리스트 조회
        function goSearchMsMaker(msMchTypeCd) {
            const param = {
                s_ms_machine_type_cd : msMchTypeCd
            };
            if (msMchTypeCd) {
                $M.goNextPageAjax(this_page + "/searchMaker", $M.toGetParam(param), {method : "GET", loader: true},
                    function(result) {
                        if (result.success) {
                            $("select#s_ms_maker_cd option").remove();
                            $('#s_ms_maker_cd').append('<option value="">' + "- 전체 -" + '</option>');

                            result.list.forEach(data => {
                                const value = data.ms_maker_cd;
                                const text = data.ms_maker_name;
                                $('#s_ms_maker_cd').append('<option value="' + value + '">' + text + '</option>');
                            });
                        }
                    }
                );
            } else {
                // 메이커 초기화
                $("select#s_ms_maker_cd option").remove();
                $('#s_ms_maker_cd').append('<option value="" >' + "- 전체 -" + '</option>');
                // 모델명 초기화
                $("select#s_ms_mch_plant_seq option").remove();
                $('#s_ms_mch_plant_seq').append('<option value="" >' + "- 전체 -" + '</option>');
            }
        }

        // 조회
		function goSearch() {

			const param = {
				s_year : $M.getValue("s_start_year"), // 조회년도
                s_ms_maker_cd : $M.getValue("s_ms_maker_cd"), // 메이커
                s_ms_mch_plant_seq : $M.getValue("s_ms_mch_plant_seq"), // 모델명
                s_ms_machine_type_cd : $M.getValue("s_ms_machine_type_cd"), // 기종
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if (result.success) {
                        // 그리드 재생성
                        AUIGrid.destroy("#auiGrid");
			            auiGrid = null;
                        createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

        // '조회결과' 그리드생성
		function createAUIGrid() {
			const gridPros = {
                showRowNumColumn : false,
                enableCellMerge: true,
			};

			let columnLayout = [
				{
					headerText : "메이커",
					dataField : "ms_maker_name",
					width : "100",
					style : "aui-center",
                    cellMerge : true, // 셀 세로 병합 실행
				},
				{
					headerText : "모델명",
					dataField : "ms_mch_name",
					style : "aui-center aui-popup",
				},
				{
					dataField : "ms_maker_cd",
					visible : false
				},
                {
					dataField : "ms_mch_plant_seq",
					visible : false
				},
			];

            let sYear = $M.getValue("s_start_year");
            for (let i=1; i<=12; i++) {
                const idxStr = String(i);
                const mon = idxStr.length < 2 ? "0" + idxStr : idxStr;
                const yearMon = sYear + mon;
				const columnObject = {
					headerText : String(yearMon).slice(0, 4) + "-" + String(yearMon).slice(4, 6),
					dataField : "a_" + yearMon + "_price",
					width : "90",
                    styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
                        return String(value).startsWith('c_') ? "aui-right-red" : "aui-right";
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        let val = String(value).startsWith('c_') ? String(value).substring(2) : value;
                        val = !!val ? AUIGrid.formatNumber(val, "#,##0") : "";
                        return val;
                    }
				};
                columnLayout.push(columnObject);
            }

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

            // 셀 클릭 바인딩
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
                // 모델명 클릭 시 [타사장비 판매가 등록] 팝업 호출
                if (event.dataField != "ms_mch_name") {
                    return false;
                }

                let param = {
					ms_mch_plant_seq : event.item.ms_mch_plant_seq
				};

				$M.goNextPage('/sale/sale0409p01', $M.toGetParam(param), {popupStatus : ""});
			});
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
    <div class="content-wrap">
        <div class="content-box">
            <!-- 메인 타이틀 -->
            <div class="main-title">
                <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            </div>
            <!-- /메인 타이틀 -->
            <div class="contents">
                <!-- 검색영역 -->
                <div class="search-wrap">
                    <table class="table">
                        <colgroup>
                            <col width="60px"> <!-- 조회년도 -->
                            <col width="90px">
                            <col width="45px"> <!-- 기종 -->
                            <col width="130px">
                            <col width="55px"> <!-- 메이커 -->
                            <col width="150px">
                            <col width="55px"> <!-- 모델명 -->
                            <col width="150px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right">조회년도</th>
                                <td>
                                    <select class="form-control ml5" id="s_start_year" name="s_start_year">
                                        <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                            <option value="${i}" <c:if test="${i == inputParam.s_current_year}">selected</c:if>>${i}년</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">기종</th>
                                <td>
                                    <select class="form-control ml5" id="s_ms_machine_type_cd" name="s_ms_machine_type_cd" onchange="goSearchMsMaker(this.value)">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${codeMap['MS_MACHINE_TYPE']}" var="item">
											<option value="${item.code_value}"> ${item.code_name} </option>
										</c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">메이커</th>
                                <td>
                                    <select class="form-control ml5" id="s_ms_maker_cd" name="s_ms_maker_cd" onchange="goSearchMachine(this.value)">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${codeMap['MS_MAKER']}" var="item">
											<option value="${item.code_value}"> ${item.code_name} </option>
										</c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">모델명</th>
                                <td>
                                    <select class="form-control ml5" id="s_ms_mch_plant_seq" name="s_ms_mch_plant_seq">
                                        <option value="">- 전체 -</option>
                                    </select>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch()">조회</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <!-- /검색영역 -->
                <!-- 그리드 타이틀, 중앙버튼 영역 -->
                <div class="title-wrap mt10">
                    <div class="left">
                        <h4>조회결과</h4>
                    </div>
                    <div class="right">
                        <div class="btn-group">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                        </div>
                    </div>
                </div>
                <!-- /그리드 타이틀, 중앙버튼 영역 -->
                <!-- 그리드-->
                <div id="auiGrid" style="margin-top: 5px; height: 570px;"></div>
                <!-- /그리드-->
            </div>
        </div>
        <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>