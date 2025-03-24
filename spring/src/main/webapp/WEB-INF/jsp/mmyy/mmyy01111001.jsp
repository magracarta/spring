<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 기안문서 > 자격취득신청 > 자격취득신청 등록
-- 작성자 : 김경빈
-- 최초 작성일 : 2024-06-12 16:00:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileCount = 5;

    var hrAbilityJson = ${hrAbilityJson};

    $(document).ready(() => {
        // 취득자격 부서 선택 이벤트 바인딩
        $("#filter_gubun_code").on("change", () => {
            var value = $("#filter_gubun_code").find(":selected").val();
            var $hrAbilitySelect = $("select#hr_code_ability_seq");
            // 초기화
            $hrAbilitySelect.find("option").remove();
            $hrAbilitySelect.append('<option value="" >- 취득자격선택 -</option>');

            // 능력 필터링
            var json = hrAbilityJson.filter(m => m.hr_ability_cd !== "01");
            if (value === "") {
                json.forEach(m => {
                    $hrAbilitySelect.append('<option value="' + m.hr_code_ability_seq + '">' + m.ability_name + '</option>');
                });
            } else {
                json
                    .filter(m => m.hr_ability_cd == value)
                    .forEach(m => {
                        $hrAbilitySelect.append('<option value="' + m.hr_code_ability_seq + '">' + m.ability_name + '</option>');
                    });
            }
        });
    });

    // 뒤로가기
	function fnList() {
		history.back();
	}

	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}
	
	// 저장
	function goSave(isRequestAppr) {
        // validation check
        if ($M.validation(document.main_form) == false) {
            return;
        }

        var msg = "";
        if (isRequestAppr != undefined) {
            $M.setValue("save_mode", "appr"); // 결재요청
            msg = "결재요청 하시겠습니까?";
        } else {
            $M.setValue("save_mode", "save"); // 저장
            msg = "저장 하시겠습니까?";
        }

        if (confirm(msg) == false) {
            return false;
        }

        var idx = 1;
        $("input[name='file_seq']").each(function () {
            var str = 'doc_file_seq_' + idx;
            if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
                $M.setValue(str, $(this).val());
            }
            idx++;
        });

        for (; idx<=fileCount; idx++) {
            $M.setValue('doc_file_seq_' + idx, '');
        }

        var frm = $M.toValueForm(document.main_form);

        $M.goNextPageAjax(this_page + "/save", frm, {method: 'POST'}, (result) => {
            if (result.success) {
                fnList();
            }
        });
    }

    /** 취득자격선택 이벤트 바인딩 */
    function fnSetRemark() {
        var seq = String($M.getValue("hr_code_ability_seq"));
        // 설명 세팅
        var remark = hrAbilityJson.filter(m => String(m.hr_code_ability_seq) === seq).map(m => m.remark);
        $M.setValue("remark", remark);
    }


    // ##### 첨부파일 관련 함수 #####

    // 파일찾기
	function fnAddFile() {
		if($("input[name='file_seq']").size() >= fileCount) {
			alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
			return false;
		}

		var param = {
			upload_type	: "DOC",
			file_type : "both",
		};

		openFileUploadPanel('setFileInfo', $M.toGetParam(param));
	}

    // 파일업로드 콜백 함수
	function setFileInfo(result) {
		var str = '';
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
		str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}

	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
		} else {
			return false;
		}
	}
</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 상세페이지 타이틀 -->
                <div class="main-title detail width780px">
                <div class="detail-left">
                    <button type="button" class="btn btn-outline-light" onclick="fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
                    <h2 style="margin-right : 25px;">자격취득신청</h2>
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="TOP_R"/>
                    </jsp:include>
                </div>
                <!-- 결재영역 -->
                <div class="p10" style="margin-left: 10px;">
                    <jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
                </div>
                <!-- /결재영역 -->
            </div>
            <!-- /상세페이지 타이틀 -->
            <div class="contents">
                <!-- 폼테이블 -->
                <table class="table-border width750px">
                    <colgroup>
                        <col width="100px">
                        <col width="">
                        <col width="100px">
                        <col width="">
                    </colgroup>
                    <tbody>
                        <tr>
                            <th class="text-right">신청자</th>
                            <td>
                                <input type="text" class="form-control width120px"
                                       id="mem_name" name="mem_name"
                                       readonly="readonly" value="${info.kor_name}" />
                                <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                            </td>
                            <th class="text-right">작성일</th>
                            <td>
                                <input type="text" class="form-control width120px"
                                       id="doc_dt" name="doc_dt"
                                       dateformat="yyyy-MM-dd" readonly="readonly"
                                       value="${inputParam.s_current_dt}" />
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">부서</th>
                            <td>
                                <input type="text" class="form-control width120px"
                                       id="org_name" name="org_name"
                                       readonly="readonly" value="${info.org_name}" />
                                <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                            </td>
                            <th class="text-right">직위</th>
                            <td>
                                <input type="text" class="form-control width120px"
                                       id="grade_name" name="grade_name"
                                       readonly="readonly" value="${info.grade_name}" />
                                <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">연락처</th>
                            <td>
                                <input type="text" class="form-control width120px"
                                       id="hp_no" name="hp_no"
                                       readonly="readonly" format="phone"
                                       value="${info.hp_no}" />
                            </td>
                            <th class="text-right">시험일시</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width110px">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate"
                                                   id="exam_dt" name="exam_dt"
                                                   dateformat="yyyy-MM-dd" disabled >
                                        </div>
                                    </div>
                                    <div class="col width40px">
                                        <input type="text" class="form-control width40px"
                                               id="exam_hour" name="exam_hour" readonly="readonly" >
                                    </div>
                                    <div class="col width16px ml5">시</div>
                                    <div class="col width40px">
                                        <input type="text" class="form-control width40px"
                                               id="exam_minute" name="exam_minute" readonly="readonly" >
                                    </div>
                                    <div class="col width16px ml5">분</div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">시험장소</th>
                            <td colspan="3">
                                <input type="text" class="form-control"
                                       id="exam_place" name="exam_place"
                                       alt="시험장소" readonly="readonly" >
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right essential-item">취득자격선택</th>
                            <td colspan="3">
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <select class="form-control" id="filter_gubun_code" name="filter_gubun_code">
                                            <option value="">- 구분선택 -</option>
                                            <c:forEach items="${codeMap['HR_ABILITY']}" var="item" varStatus="status">
                                                <c:if test="${item.code_value ne '01'}">
                                                    <option value="${item.code_value}" >${item.code_name}</option>
                                                </c:if>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col" style="width: 545px;">
                                        <select class="form-control rb" id="hr_code_ability_seq" name="hr_code_ability_seq" required="required" alt="취득자격선택" onchange="fnSetRemark()">
                                            <option value="">- 취득자격선택 -</option>
                                            <c:forEach var="item" items="${hrAbilityList}">
                                                <option value="${item.hr_code_ability_seq}">${item.ability_name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">설명</th>
                            <td colspan="3">
                                <textarea class="form-control" id="remark" name="remark" style="height: 100px;" alt="설명" readonly="readonly"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">첨부파일</th>
                            <td colspan="3">
                                <div class="table-attfile doc_file_div" style="width:100%;">
                                    <div class="table-attfile" style="float:left">
                                        <button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="fnAddFile()">파일찾기</button>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <!-- /폼테이블 -->
                <!-- 하단 내용 -->
                <div class="doc-com width750px">
                    <div class="text">
                        상기와 같은 용도로 자격취득신청을 요청합니다.<br>
                        ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                    </div>
                    <div class="detail-info">
                        부서 : ${info.org_name}<br>
                        성명 : ${info.kor_name}
                    </div>
                </div>
                <!-- /하단 내용 -->
                <div class="btn-group mt10 width750px">
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- /contents 전체 영역 -->
</div>
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value=""/>
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value=""/>
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value=""/>
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value=""/>
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value=""/>
</form>	
</body>
</html>