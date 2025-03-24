<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 기안문서 > 자격취득신청 > 자격취득상세
-- 작성자 : 김경빈
-- 최초 작성일 : 2024-06-12 15:58:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileMaxCount = 5;

    var hrAbilityJson = ${hrAbilityJson};
    // 결재처리 버튼 노출 여부
    var isShowApprBtn = ${isShowApprBtn};

    // 결재자 여부
    var isNextApprMem = ${isNextApprMem};
    // 구분 = 써티 여부
    var isCertiCode = ${isCertiCode};
    // 결재중 여부
    var isInAppr = ${isInAppr};
    // 써티인 경우 쪽지 보냄 여부
    var hasSendPaper = ${hasSendPaper};




	$(document).ready(function() {
        // 첨부파일 세팅
		<c:forEach var="list" items="${doc_file}">
        setFileInfo('${list.file_seq}', '${list.file_name}');
        </c:forEach>

        fnSetAuthColumn();
        fnCtrlByAppr();

        // 결재자용 버튼 처리
        var apprSaveBtn = $("#goSaveBtnForApprMem");
        if ("${apprSaveBtnShowYn}" === "Y") {
            apprSaveBtn.show();
            apprSaveBtn.prop("disabled", false);
        } else {
            apprSaveBtn.hide();
        }

        // 결재처리 버튼 노출 로직
        var apprBtn = $("#_goApproval");
        if (isShowApprBtn) {
            apprBtn.show();
            apprBtn.prop("disabled", false);
        } else {
            apprBtn.hide();
        }

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

    // 결재상태에 따른 수정 제어
    function fnCtrlByAppr() {
        var isMyPage = "${SecureUser.mem_no}" === "${info.mem_no}";

        switch ("${apprBean.appr_proc_status_cd}") {
            case "01": // 작성중
                if (!isMyPage) {
                    disableAll();
                } else {
                    // 시험일시는 수정 불가
                    $("#exam_dt").parent("div").children().prop("disabled", true);
                }
                $("#btn_certi_report").prop("disabled", true); // 써티자격증확인 버튼
                break;

            case "03": // 결재중
                disableAll();
                if (isNextApprMem) { // 결재자
                    if (isCertiCode) {
                        $("#exam_dt").parent("div").children().prop("disabled", false)
                        $("#exam_hour").prop("disabled", false);
                        $("#exam_minute").prop("disabled", false);
                        $("#exam_place").prop("disabled", false);
                    }

                } else if (isMyPage) { // 본인페이지
                    $("#_goApprCancel").prop("disabled", false);
                }
                $("#btn_certi_report").prop("disabled", true); // 써티자격증확인 버튼
                break;

            case "05": // 결재완료
                disableAll();
                $("#btn_certi_report").prop("disabled", false); // 써티자격증확인 버튼
                break;
        }

        function disableAll() {
            $("#main_form :input").prop("disabled", true);
            $("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
        }
    }

    /**
     * 취득자격선택 이벤트 바인딩<br>
     * 시험일시 및 시험장소 readonly 처리<br>
     * 설명 세팅
     */
    function fnSetAuthColumn() {
        // 취득자격 구분이 써티(02) 인지
        var seq = String($M.getValue("hr_code_ability_seq"));
        var json = hrAbilityJson.filter(m => String(m.hr_code_ability_seq) === seq);
        var hrAbilityCd = json.map(m => m.hr_ability_cd);
        $M.setValue("hr_ability_cd", hrAbilityCd);
        isCertiCode = String(hrAbilityCd) === "02";

        // 결재중 여부
        var setReadonly = !(isCertiCode && isNextApprMem && isInAppr);

        $("#exam_dt").prop("readonly", setReadonly);
        $("#exam_hour").prop("readonly", setReadonly);
        $("#exam_minute").prop("readonly", setReadonly);
        $("#exam_place").prop("readonly", setReadonly);

        // 비어있다면 default 값 세팅
        if (!setReadonly) {
            if (!$M.getValue("exam_dt")) {
                $M.setValue("exam_dt", "${inputParam.s_current_dt}");
            }
            if (!$M.getValue("exam_hour")) {
                $M.setValue("exam_hour", "12");
            }
            if (!$M.getValue("exam_minute")) {
                $M.setValue("exam_minute", "00");
            }
            if (!$M.getValue("exam_place")) {
                $M.setValue("exam_place", "해당 없음");
            }
        }

        $M.setValue("ability_name", $("#hr_code_ability_seq option:selected").text());

        // 설명 세팅
        $M.setValue("remark", json.map(m => m.remark));
    }


    // 닫기
	function fnClose() {
		window.close();
	}

    // 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
	}

    // 결재처리
    function goApproval() {
        // validation check
        if (isCertiCode) {
            var checkField = {field:['exam_dt', 'exam_hour', 'exam_minute', "exam_place"]}
            if (!$M.validation(document.main_form, checkField)) {
                return;
            }
        }

        var param = {
            appr_job_seq: "${apprBean.appr_job_seq}",
            seq_no: "${apprBean.seq_no}"
        };
        openApprPanel("goApprovalResult", $M.toGetParam(param));
    }

    // 결재처리 콜백
    function goApprovalResult(result) {
        $M.goNextPageAjax('/session/check', '', {method: 'GET'}, function (sessionResult) {
            if (sessionResult.success) {
                if (result.appr_status_cd == '03') {
                    alert("반려가 완료되었습니다.");
                    location.reload();
                } else {
                    $M.setValue("save_mode", "approval"); // 승인
                    fnModifyLogic();
                }
            }
        });
    }

	// 결재취소
	function goApprCancel() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}",
			appr_cancel_yn: "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}

    // 결재취소 콜백
	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method: 'GET'},
			function (result) {
				if (result.success) {
					alert("결재취소가 완료됐습니다.");
					location.reload();
				}
			}
		);
	}

    /**
     * 수정
     * @param type request type
     */
	function goModify(type) {
		// validation check
		if (!$M.validation(document.main_form)) {
			return;
		}

		var msg = "";
		if (type) {
			// 결재요청 Setting
			$M.setValue("save_mode", "appr");
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "modify");
			msg = "수정 하시겠습니까?";
            // 써티 & 결재중인 경우
            if (isCertiCode && isInAppr) {
                // 시험일시, 시험장소 필수
                var options = {field:['exam_dt', 'exam_hour', 'exam_minute']};
                if (!$M.validation(document.main_form, options)) {
                    return;
                }
                // 시험일시, 시험장소 변경 여부
                var modifiedYn = "N";
                var checkCols = ["exam_place", "exam_dt", "exam_hour", "exam_minute"];
                checkCols.forEach(col => {
                    var data = ${infoJson};
                    if (data[col] != $M.getValue(col)) {
                        modifiedYn = "Y";
                    }
                });
                $M.setHiddenValue("modifiedYn", modifiedYn);
            }
		}

		if (!confirm(msg)) {
			return false;
		}

        fnModifyLogic();
	}

    // 수정 로직
    function fnModifyLogic() {
        var idx = 1;
		$("input[class='doc_file_list']").each(function() {
			var str = 'doc_file_seq_' + idx;
			$M.setValue(str, $(this).val());
			idx++;
		});

		for(; idx<=fileMaxCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, 0);
		}

		var frm = $M.toValueForm(document.main_form);

		$M.goNextPageAjax(this_page + "/modify", frm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
					window.location.reload();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
    }

    // 써티자격증확인
    function goReportCerti() {
        if ("${apprBean.appr_proc_status_cd}" !== "05") {
            alert("결재 완료 후 발급됩니다.");
            return false;
        }

        var param = 'doc_no=' + $M.getValue("doc_no");
        openReportPanel('mmyy/mmyy011110p01_01.crf', param);
    }

    // ##### 첨부파일 관련 함수 #####

	// 첨부파일
	function goSearchFile(){
		if($("input[class='doc_file_list']").size() >= fileMaxCount) {
			alert("파일은 " + fileMaxCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
        var param = {
            upload_type: 'DOC',
            file_type: 'both',
        };
        
		openFileUploadPanel('fnPrintFileInfo', $M.toGetParam(param));
	}
	
	function fnPrintFileInfo(result) {
		setFileInfo(result.file_seq, result.file_name)
	}
	
	//첨부파일 세팅
	function setFileInfo(fileSeq, fileName) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" class="doc_file_list" name="doc_file_seq_'+ fileIndex + '" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) { 
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
			$("#doc_file_seq_" + fileIndex).remove();
		} else {
			return false;
		}
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${info.appr_job_seq}" />
    <input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${info.appr_proc_status_cd}">
    <input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}" ><%-- PK value --%>
    <input type="hidden" id="hr_ability_cd" name="hr_ability_cd" />
    <input type="hidden" id="ability_name" name="ability_name" />

    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="title-wrap">
                <div class="left approval-left"></div>
                <!-- 결재영역 -->
                <div class="pl10">
                    <jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
                </div>
                <!-- /결재영역 -->
            </div>
            <!-- 폼테이블 -->
            <table class="table-border mt10">
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
                                   readonly="readonly" value="${info.mem_name}" />
                            <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                        </td>
                        <th class="text-right">작성일</th>
                        <td>
                            <input type="text" class="form-control width120px"
                                   id="doc_dt" name="doc_dt"
                                   dateformat="yyyy-MM-dd" readonly="readonly"
                                   value="${info.doc_dt}" />
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
                                               dateformat="yyyy-MM-dd" value="${info.exam_dt}" >
                                    </div>
                                </div>
                                <div class="col width40px">
                                    <input type="text" class="form-control width40px"
                                           id="exam_hour" name="exam_hour"
                                           format="num" maxlength="2" alt="시험일시 시험시간"
                                           value="${info.exam_hour}">
                                </div>
                                <div class="col width16px ml5"><label for="exam_hour">시</label></div>
                                <div class="col width40px">
                                    <input type="text" class="form-control width40px"
                                           id="exam_minute" name="exam_minute"
                                           format="num" maxlength="2" alt="시험일시 시험시간"
                                           value="${info.exam_minute}" >
                                </div>
                                <div class="col width16px ml5"><label for="exam_minute">분</label></div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">시험장소</th>
                        <td colspan="3">
                            <input type="text" class="form-control"
                                   id="exam_place" name="exam_place"
                                   maxlength="15"
                                   alt="시험장소" value="${info.exam_place}" >
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
                                <div class="col" style="width: 649px;">
                                    <select class="form-control rb" id="hr_code_ability_seq" name="hr_code_ability_seq" required="required" alt="취득자격선택" onchange="fnSetAuthColumn()">
                                        <option value="">- 취득자격선택 -</option>
                                        <c:forEach var="item" items="${hrAbilityList}" varStatus="">
                                            <option value="${item.hr_code_ability_seq}"
                                                    <c:if test="${info.hr_code_ability_seq eq item.hr_code_ability_seq}">selected</c:if>
                                            >${item.ability_name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">설명</th>
                        <td colspan="3">
                            <textarea class="form-control" id="remark" name="remark"
                                      style="height: 100px;" alt="설명" readonly="readonly" value="${info.remark}"></textarea>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">첨부파일</th>
                        <td colspan="3">
                            <div class="table-attfile doc_file_div" style="width:100%;">
                                <div class="table-attfile" style="float:left">
                                    <button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="goSearchFile()">파일찾기</button>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">자격증파일</th>
                        <td colspan="3">
                            <button type="button" class="btn btn-primary-gra mr10" name="btn_certi_report" id="btn_certi_report" onclick="goReportCerti()">써티자격증확인</button>
                            <input type="hidden" id="certi_no" name="certi_no" value="${info.certi_no}">
                        </td>
                    </tr>
                </tbody>
            </table>
            <!-- /폼테이블 -->
            <!-- 하단 내용 -->
            <div class="doc-com">
                <div class="text">
                    상기와 같은 용도로 자격취득신청을 요청합니다.<br>
                    ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                </div>
                <div class="detail-info">
                    부서 : ${info.org_name}<br>
                    성명 : ${info.mem_name}
                </div>
            </div>
            <!-- /하단 내용 -->
            <!-- 결재자 의견 -->
            <div>
                <div class="title-wrap mt10">
                    <div class="left">
                        <h4>결재자 의견</h4>
                    </div>
                </div>
                <table class="table mt5">
                    <colgroup>
                        <col width="40px">
                        <col width="">
                        <col width="60px">
                        <col width="">
                    </colgroup>
                    <tr>
                        <td colspan="5">
                            <div class="fixed-table-container" style="width: 100%; height: 110px;">
                                <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
                                <div class="fixed-table-wrapper">
                                    <table class="table-border doc-table md-table">
                                        <colgroup>
                                            <col width="40px">
                                            <col width="140px">
                                            <col width="55px">
                                            <col width="">
                                        </colgroup>
                                        <thead>
                                        <!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
                                        <tr>
                                            <th class="th" style="font-size: 12px !important">구분</th>
                                            <th class="th" style="font-size: 12px !important">결재일시</th>
                                            <th class="th" style="font-size: 12px !important">담당자</th>
                                            <th class="th" style="font-size: 12px !important">특이사항</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="list" items="${apprMemoList}">
                                            <tr>
                                                <td class="td"
                                                    style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
                                                <td class="td"
                                                    style="font-size: 12px !important">${list.proc_date }</td>
                                                <td class="td"
                                                    style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
                                                <td class="td" style="font-size: 12px !important">${list.memo }</td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            <!-- /결재자 의견 -->
			<div class="btn-group mt10">
				<div class="right">
                    <button type="button" class="btn btn-info" id="goSaveBtnForApprMem" name="goSaveBtnForApprMem" onclick="goModify()">수정</button>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                        <jsp:param name="appr_yn" value="Y"/>
                    </jsp:include>
				</div>
			</div>
        </div>
    </div>
    <!-- /팝업 -->
    <input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value="${info.doc_file_seq_1 }" />
    <input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value="${info.doc_file_seq_2 }" />
    <input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value="${info.doc_file_seq_3 }" />
    <input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value="${info.doc_file_seq_4 }" />
    <input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value="${info.doc_file_seq_5 }" />
</form>
</body>
</html>