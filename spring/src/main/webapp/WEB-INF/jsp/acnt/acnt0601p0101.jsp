<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 직원관리상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-14 20:03:57
-- 2022-12-19 jsk : erp3-2차 권한관리 수정
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<style type="text/css">
		#profileImage {
			max-width: 180px;
			max-height: 180px;
		}
	</style>

	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var defaultImg = "/static/img/icon-user.png";
		var auiGridMove; // 발령사항
		var auiGridAssetPayment; // 지급품목
		var auiGridCareer; // 경력사항
		var auiGridLicense; // 자격사항
		var orgList = orgListJson;
		var gradeList = JSON.parse('${codeMapJsonObj['GRADE']}');
		var jobList = JSON.parse('${codeMapJsonObj['JOB']}');
		var appointList = JSON.parse('${codeMapJsonObj['APPOINT_TYPE']}');
		var authEditLicense = true;
		var misuFlag = ${misuFlag}; // 이관할 미수담당이 있는지 확인
		var todoFlag = ${todoFlag}; // 이관할 미결사항이 있는지 확인

		$(document).ready(function () {

			fnInit();

			createAUIGridMove(); // 발령사항 그리드 생성
			createAUIGridauiGridAssetPayment(); // 지급품목 그리드 생성
			createAUIGridCareer(); // 경력사항 그리드 생성
			createAUIGridLicense(); // 자격사항 그리드 생성

			fnSetOrgAuthCd(); // 부서권한 세팅
			fnSetJobAuthCd(); // 업무권한 세팅

			// 기본 프로필 이미지 크기 세팅
			if ($("#profileImage").attr("src") == defaultImg) {
				$("#profileImage").width(150);
			}

			$("#retireField").children("button").addClass("btn-cancel");
			$("#retireField").children("button").attr("disabled", true);

			//퇴직여부 확인
			if ($M.getValue("work_status_cd") == "04") {
				fnRetireYn(true);
			} else {
				fnRetireYn(false);
			}

			$("#work_status_cd").change(function () {
				if ($M.getValue("work_status_cd") == "04") {
					fnRetireYn(true);
				} else {
					fnRetireYn(false);
				}
			});
			// END 퇴직여부 확인

			// 직급 변경 이벤트
			$('#job_select_box').change(function () {
				console.log("직급 변경 : " + this.value);
				$M.setValue("job_cd", this.value);
			});

			// 직책 변경 이벤트
			$('#grade_select_box').change(function () {
				console.log("직책 변경 : " + this.value);
				$M.setValue("grade_cd", this.value);
				fnSetOrgAuth();
			});

			// 프로필 이미지 X버튼 클릭 시 이벤트
			$("#fileRemoveBtn").on("click", function (e) {
				fnRemoveFile();
			});

			// 아이디 소문자 변경
			$("#web_id").focusout(function () {
				var web_id = $M.nvl($M.getValue("web_id"), "");
				if (web_id != "") {
					var lowerWebId = web_id.toLowerCase();
					$M.setValue("web_id", lowerWebId);
				}
			});

			// 이메일 소문자 변경
			$("#email").focusout(function () {
				var email = $M.nvl($M.getValue("email"), "");
				if (email != "") {
					var lowerEmail = email.toLowerCase();
					$M.setValue("email", lowerEmail);
				}
			});

			// webid 중복체크 완료 후 webid 변경 시 중복체크 다시 실행
			$("#web_id").on("propertychange change keyup paste input", function () {
				var web_id = $M.nvl($M.getValue("web_id"), "");
				var origin_web_id = $M.nvl($M.getValue("origin_web_id"), "");
				if ($M.getValue("lastchk_web_id") == this.value) {
					$M.setValue("web_id_chk", "Y");
					$("#btn_web_id_chk").prop("disabled", true);
				} else if (web_id == origin_web_id) {
					$M.setValue("web_id_chk", "Y");
					$("#btn_web_id_chk").prop("disabled", true);
				} else {
					$M.setValue("web_id_chk", "N");
					$("#btn_web_id_chk").prop("disabled", false);
				}
			});

			// eamil 변경 시 webid 중복체크 다시 실행
			$("#email").on("propertychange change keyup paste input", function () {
				var email = $M.nvl($M.getValue("email"), "");
				var origin_email = $M.nvl($M.getValue("origin_email"), "");
				if ($M.getValue("lastchk_email") == this.value) {
					$M.setValue("web_id_chk", "Y");
					$("#btn_web_id_chk").prop("disabled", true);
				} else if (email == origin_email) {
					$M.setValue("web_id_chk", "Y");
					$("#btn_web_id_chk").prop("disabled", true);
				} else {
					$M.setValue("web_id_chk", "N");
					$("#btn_web_id_chk").prop("disabled", false);
				}
			});

			// 핸드폰번호 중복체크 완료 후 번호 변경 시 중복체크 다시 실행
			$("#hp_no").on("propertychange change keyup paste input", function () {
				var hp_no = $M.nvl($M.getValue("hp_no"), "");
				var origin_hp_no = $M.nvl($M.getValue("origin_hp_no"), "");

				if ($M.getValue("lastChk_hp_no") == hp_no) {
					$M.setValue("hp_no_chk", "Y");
					$("#btn_hp_no_chk").prop("disabled", true);
				} else if (hp_no == origin_hp_no) {
					$M.setValue("hp_no_chk", "Y");
					$("#btn_hp_no_chk").prop("disabled", true);
				} else {
					$M.setValue("hp_no_chk", "N");
					$("#btn_hp_no_chk").prop("disabled", false);
				}
			});

			// 주민등록번호 중복체크 완료 후 번호 변경 시 중복체크 다시 실행
			$("#resi_no1, #resi_no2").on("propertychange change keyup paste input", function () {
				var resi_no1 = $M.nvl($M.getValue("resi_no1"), "");
				var resi_no2 = $M.nvl($M.getValue("resi_no2"), "");
				var resi_no = resi_no1 + resi_no2;
				var origin_resi_no = $M.nvl($M.getValue("origin_resi_no"), "");

				// 주민등록번호 입력 안할 시 중복체크X
				if (resi_no == "") {
					$M.setValue("resi_no_chk", "Y");
					$("#btn_resi_no_chk").prop("disabled", true);
					return;
				}

				if ($M.getValue("lastChk_resi_no") == resi_no) {
					$M.setValue("resi_no_chk", "Y");
					$("#btn_resi_no_chk").prop("disabled", true);
				} else if (resi_no == origin_resi_no) {
					$M.setValue("resi_no_chk", "Y");
					$("#btn_resi_no_chk").prop("disabled", true);
				} else {
					$M.setValue("resi_no_chk", "N");
					$("#btn_resi_no_chk").prop("disabled", false);
				}
			});

			// 이관할 데이터가 있는 경우 레이아웃 설정 - 김경빈
			if (misuFlag || todoFlag) {
				$("#yiguan_table").show();
				if (!misuFlag) {
					$("#misu_th").hide();
					$("#misu_td").hide();
				}
				if (!todoFlag) {
					$("#todo_th").hide();
					$("#todo_td").hide();
				}
			} else {
				$("#yiguan_table").hide();
			}
		});

		function fnInit() {
			var secureOrgCode = "${SecureUser.org_code}";
			var secureMemNo = "${SecureUser.mem_no}";

			if (("${page.fnc.F00768_001}"== "Y") == false) {
				$("#_fnAdd").prop("disabled", true);
			}

			if (("${page.fnc.F00768_001}"== "Y") == false && secureMemNo != $M.getValue("mem_no")) {
				$("#_fnAddSec").prop("disabled", true);
				authEditLicense = false;
			}
		}

		// 부서권한 세팅
		function fnSetOrgAuthCd() {
			var orgAuthCd = "${bean.org_auth_cd}";
			var orgAuthCdMulti = "";

			if (orgAuthCd.indexOf("#") != -1) {
				// 다중
				orgAuthCdMulti = orgAuthCd.split("#");
				$M.setValue("org_auth_cd", orgAuthCdMulti);
			} else {
				// 단일
				$M.setValue("org_auth_cd", orgAuthCd);
			}
		}

		// 업무권한 세팅
		function fnSetJobAuthCd() {
			var jobAuthCd = "${bean.job_auth_cd}";
			var jobAuthCdMulti = "";

			if (jobAuthCd.indexOf("#") != -1) {
				// 다중
				jobAuthCdMulti = jobAuthCd.split("#");
				$M.setValue("job_auth_cd", jobAuthCdMulti);
			} else {
				// 단일
				$M.setValue("job_auth_cd", jobAuthCd);
			}
		}

		// 재직구분 선택 시 이벤트
		function fnRetireYn(flag) {

			if (flag) {
				$("#retire_dt").attr("readonly", false);						// 퇴직일 입력가능
				$("#retireField").children("button").attr("disabled", false);	// 퇴직일 달력 사용가능
				$("#retire_dt").attr("required", true);							// 퇴직일 필수
				$("#cert_company_opinion").attr("readonly", false);				// 퇴직 시, 회사의견 입력가능
				$("#btn_search_misu_mem").attr("disabled", false);				// 퇴직 시, 직원조회 버튼 활성

				// 이관할 데이터가 있다면 팝업창 띄우기
				if (misuFlag || todoFlag) {
					if (confirm("미결업무 및 미수담당이 있습니다. 확인하시겠습니까?")) {
						goRetireYiguan();
					}
				}

				// 이관해야할 데이터가 있다면
				if (misuFlag) {
					$("#misu_mem_no").attr("required", true); // 이관 미수담당자 필수
				}
				if (todoFlag) {
					$("#todo_mem_no").attr("required", true); // 이관 미결담당자 필수
				}

			} else {
				$("#retire_dt").attr("readonly", true);							// 퇴직일 입력불가
				$("#retireField").children("button").attr("disabled", true);	// 퇴직일 달력 사용불가
				$("#retire_dt").attr("required", false);						// 퇴직일 필수X
				$("#cert_company_opinion").attr("readonly", true);				// 퇴직 시 회사의견 입력불가
				$("#misu_mem_no").attr("required", false); 						// 이관 미수담당자 필수 X
				$("#todo_mem_no").attr("required", false); 						// 이관 미결담당자 필수 X

				$M.setValue("retire_dt", "");									// 퇴직일 초기화
				$M.setValue("cert_company_opinion", "");						// 퇴직 시 회사의견 초기화
				$M.setValue("misu_mem_name", "");								// 재직 시, 이관 미수담당자 초기화
				$M.setValue("misu_mem_no", "");									// 재직 시, 이관 미수담당자 코드 초기화
				$M.setValue("todo_mem_name", "");								// 재직 시, 이관 인계담당자 초기화
				$M.setValue("todo_mem_no", "");									// 재직 시, 이관 인계담당자 코드 초기화
			}
		}

		// 주소값 세팅
		function fnSetAddress(data) {
			$M.setValue("home_post_no", data.zipNo);
			$M.setValue("home_addr1", data.roadAddrPart1);
			$M.setValue("home_addr2", data.addrDetail);
		}

		// 프로필 이미지 삭제
		function fnRemoveFile() {
			$("#profile").remove();
			$("#profileImage").attr("src", defaultImg).width(150);
			$M.setValue("pic_file_seq", "0");
		}

		// 핸드폰번호 중복체크
		function goHpNoCheck() {
			var hpNoCheck = $M.nvl($M.getValue("hp_no"), "");

			if (hpNoCheck == "") {
				alert("핸드폰번호를 입력해주세요");
				return;
			}

			if (hpNoCheck != "Y") {
				$M.goNextPageAjax(this_page + "/hpNoCheck/" + hpNoCheck, "", {method: "get"},
						function (result) {
							if (result.success) {
								$M.setValue("hp_no_chk", "Y");
								$M.setValue("lastChk_hp_no", $M.getValue("hp_no"));
								$("#btn_hp_no_chk").prop("disabled", true);
							} else {
								$M.setValue("hp_no_chk", "N");
								$("#btn_hp_no_chk").prop("disabled", false);
							}
						}
				);
			} else {
				alert("사용가능한 핸드폰번호 입니다");
			}
		}

		// 프로필 사진 등록 시 마우스(onmouseover) 삭제버튼 show
		function fnDelBtnShow() {
			if ($("#profileImage").attr("src") != defaultImg) {
				$(".profilephoto-delete").show();
			}
		}

		// 마우스(onmouseout) 삭제버튼 hide
		function fnDelBtnHide() {
			$(".profilephoto-delete").hide();
		}

		// 파일 업로드
		function goUploadImg(rowIndex) {
			var param = {
				upload_type: "MEM",
				file_type: "img",
				max_size: 1024,
				max_height: 200,
				max_width: 200,
			};

			if (rowIndex != undefined) {
				$M.setValue("license_row_index", rowIndex);
				openFileUploadPanel("fnSetLicenseImage", $M.toGetParam(param));
			} else {
				openFileUploadPanel("fnSetImage", $M.toGetParam(param));
			}
		}

		// 파일업로드 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result !== null && result.file_seq !== null) {
				$M.setValue("pic_file_seq", result.file_seq);
				$("#profileImage").attr("src", "/file/" + result.file_seq + "").width(188);
			}
		}

		// 자격사항 이미지 값 Setting
		function fnSetLicenseImage(result) {
			if (result !== null && result.file_seq !== null) {
				AUIGrid.updateRow(auiGridLicense, {license_file_seq : result.file_seq}, $M.getValue("license_row_index"));
				AUIGrid.updateRow(auiGridLicense, {origin_file_name : result.file_name}, $M.getValue("license_row_index"));
			}
		}

		function fnPreview(fileSeq) {
			var params = {
				file_seq : fileSeq
			};
			var popupOption = "";
			$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 아이디 중복검사
		function goWebIdCheck() {

			if ($M.nvl($M.getValue("web_id"), "") == "") {
				alert("아이디를 입력해주세요");
				return;
			}

			if ($M.nvl($M.getValue("email"), "") == "") {
				alert("이메일을 입력해주세요");
				return;
			}

			if ($M.getValue("web_id_chk") != "Y") {
				var getEmail = $M.getValue("email");

				if (getEmail.indexOf('@') == -1) {
					alert("이메일 형식이 맞지 않습니다.");
					return;
				}

				var email = getEmail.substring(0, getEmail.indexOf('@'));

				var param = {
					"web_id": $M.getValue("web_id"),
					"email": email,
				};

				$M.goNextPageAjax(this_page + "/webIdCheck", $M.toGetParam(param), {method: "get"},
						function (result) {
							if (result.success) {
								$M.setValue("lastchk_web_id", $M.getValue("web_id"));
								$M.setValue("web_id_chk", "Y");
								$("#btn_web_id_chk").prop("disabled", true);

							} else {
								$M.setValue("web_id_chk", "N");
								$("#btn_web_id_chk").prop("disabled", false);
							}
						}
				);
			} else {
				alert("사용가능한 아이디 입니다.");
			}
		}


		// 주민등록번호 체크
		function goResiNoCheck() {

			var resi_no1 = $M.nvl($M.getValue("resi_no1"), "");
			var resi_no2 = $M.nvl($M.getValue("resi_no2"), "");
			var resi_no = resi_no1 + resi_no2;

			var param = {
				"resi_no": resi_no,
			};

			$M.goNextPageAjax(this_page + "/resiNoCheck/", $M.toGetParam(param), {method: "post"},
					function (result) {
						if (result.success) {
							$M.setValue("lastChk_resi_no", resi_no);
							$M.setValue("resi_no_chk", "Y");
							$("#btn_resi_no_chk").prop("disabled", true);
						} else {
							$M.setValue("resi_no_chk", "N");
							$("#btn_resi_no_chk").prop("disabled", false);
						}
					}
			);
		}

		// 주민등록번호 마스킹 해지기능
		function fnShowResiNo() {
			if($M.getValue("resi_no_show_yn") == "N") {
				$M.setValue("resi_no_show_yn", "Y");
				$("#btn_show_resi_no").html("감추기");
				$('#resi_no2').prop("type", "text");
			} else {
				$M.setValue("resi_no_show_yn", "N");
				$("#btn_show_resi_no").html("보기");
				$('#resi_no2').prop("type", "password");
			}
		}

		// 경력사항 행 추가
		function fnAdd() {
			// 그리드 필수값 체크
			if (fnCheckCareerGridEmpty(auiGridCareer)) {

				var item = new Object();

				item.career_seq_no = -1;
				item.career_st_dt = "";
				item.career_ed_dt = "";
				item.cmp_name = "";
				item.job_text = "";
				item.career_grade_name = "";
				item.career_remark = "";
				item.career_use_yn = "Y";
				item.career_cmd = "C";

				AUIGrid.addRow(auiGridCareer, item, "last");
			}
		}

		// 경력사항 그리드 필수값 체크
		function fnCheckCareerGridEmpty() {
			return AUIGrid.validateGridData(auiGridCareer, ["career_st_dt", "cmp_name"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 경력사항 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGridCareer, "경력사항");
		}

		// 자격사항 행 추가
		function fnAddSec() {
			// 그리드 필수값 체크
			if (fnCheckLicenseGridEmpty(auiGridLicense)) {

				var item = new Object();

				item.license_seq_no = -1;
				item.license_dt = "";
				item.license_kind = "";
				item.content = "";
				item.license_biz_name = "";
				item.license_no = "";
				item.origin_file_name = "";
				item.license_use_yn = "Y";
				item.license_cmd = "C";
				item.license_file_seq = 0;

				AUIGrid.addRow(auiGridLicense, item, "last");
			}
		}

		// 자격사항 그리드 필수값 체크
		function fnCheckLicenseGridEmpty() {
			return AUIGrid.validateGridData(auiGridLicense, ["license_dt", "license_kind", "content"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 자격사항 엑셀다운로드
		function fnExcelDownSec() {
			fnExportExcel(auiGridLicense, "자격사항");
		}

		// 발령사항 엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGridMove, "발령사항");
		}

		// 지급품목 엑셀다운로드
		function fnExcelDownFourth() {
			fnExportExcel(auiGridAssetPayment, "지급품목");
		}

		// 직급/ 직책 저장 클릭 이벤트
		function handlerGradeJobSaveClick() {
			var param = {
				"grade_cd" : $M.getValue("grade_cd"),
				"job_cd" : $M.getValue("job_cd"),
				"mem_no" : $M.getValue("mem_no"),
			}

			$M.goNextPageAjaxModify(this_page + "/saveGradeAndJob", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							window.location.reload();
						}
					}
			);
		}

		// 저장
		function goModify() {
			var sResi_No = $M.getValue("resi_no1") + $M.getValue("resi_no2");
			$M.setValue("resi_no", sResi_No);

			// 부서권한 필수체크
			if ($M.nvl($M.getValue("org_code"), "") != "") {
				if ($M.nvl($M.getValue("org_auth_cd"), "") == "") {
					alert("부서권한이 없습니다. 직책관리 메뉴에서 부서권한 설정 후 처리해주세요.");
					return;
				}
			}

			if ( ($('#misu_mem_no').prop('required') && $M.getValue("misu_mem_no") === "")
					|| ($('#todo_mem_no').prop('required') && $M.getValue("todo_mem_no") === "")) {
				if (confirm("미결업무 및 미수담당이 있습니다. 확인하시겠습니까?")) {
					goRetireYiguan();
					return;
				}
			}

			// validation check
			if ($M.validation(document.main_form) === false) {
				return;
			}

			if ($M.getValue("web_id_chk") == "N") {
				alert("아이디 중복검사를 진행해주세요");
				return;
			}

			if (sResi_No != "" && $M.getValue("resi_no_chk") == "N") {
				alert("주민등록번호 중복검사를 진행해주세요");
				return;
			}

			if ($M.getValue("hp_no_chk") == "N") {
				alert("핸드폰 번호 중복검사를 진행해주세요");
				return;
			}

			if (fnCheckCareerGridEmpty(auiGridCareer) === false) {
				return false;
			}

			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridCareer, auiGridLicense];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxModify(this_page + "/modify", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							window.location.reload();
						}
					}
			);
		}

		// 발령사항 그리드 생성
		function createAUIGridMove() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "발령일자",
					dataField: "move_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width : "85",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "구분",
					dataField: "mem_move_name",
					width : "100",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "발령사항",
					dataField: "move_content",
					width : "310",
					minWidth : "300",
					style: "aui-left"
				},
				{
					headerText: "비고",
					dataField: "remark",
					width : "200",
					minWidth : "190",
					style: "aui-left"
				}
			];

			auiGridMove = AUIGrid.create("#auiGridMove", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridMove, moveListJson);
			$("#auiGridMove").resize();
		}

		// 지금품목 그리드 생성
		function createAUIGridauiGridAssetPayment() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "관리번호",
					dataField: "asset_payment_no",
					width : "60",
					minWidth : "50",
					style: "aui-center"
				},
				{
					headerText: "매입일",
					dataField: "buy_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "구분",
					dataField: "asset_owner_name",
					width : "90",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText : "보관처",
					dataField : "use_kor_name",
					width : "65",
					minWidth : "65",
					style : "aui-center",
					editable : false,
				},
				{
					headerText: "보관부서",
					dataField: "use_org_name",
					width : "80",
					minWidth : "80",
					style: "aui-center"
				},
				{
					headerText: "물품구분",
					dataField: "asset_type_name",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "구입처",
					dataField: "buy_office",
					width : "120",
					minWidth : "110",
					style: "aui-center"
				},
				{
					headerText: "제조사/브랜드",
					dataField: "maker_brand",
					width : "120",
					minWidth : "110",
					style: "aui-center"
				},
				{
					headerText: "구입금액",
					dataField: "buy_amt",
					width : "80",
					minWidth : "70",
					style: "aui-right",
					dataType: "numeric",
					formatString: "#,##0"
				},
				/*	15288 컬럼 정리 전호형
				{
					headerText: "상태",
					dataField: "asset_owner_name",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				}
				*/
			];

			auiGridAssetPayment = AUIGrid.create("#auiGridAssetPayment", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridAssetPayment, assetPaymentListJson);
			$("#auiGridAssetPayment").resize();
		}

		// 경력사항 그리드 생성
		function createAUIGridCareer() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				showStateColumn: true,
				editable: true
			};

			// 관리부가 아니면 editable = false
			if(("${page.fnc.F00768_001}" == "Y") == false) {
				gridPros.editable = false;
			}

			var columnLayout = [
				{
					headerText: "시작일자",
					dataField: "career_st_dt",
					dataType: "date",
					width : "80",
					minWidth : "70",
					dataInputString: "yyyymmdd",
					formatString: "yyyy-mm-dd",
					editRenderer: {
						type: "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat: "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength: 8,
						onlyNumeric: true, // 숫자만
						validator: function (oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							if (newValue == "") {
								// 날짜 지울 시 검사X
								return;
							}
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver: true
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${page.fnc.F00768_001}" == "Y") {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "종료일자",
					dataField: "career_ed_dt",
					dataType: "date",
					width : "80",
					minWidth : "70",
					dataInputString: "yyyymmdd",
					formatString: "yyyy-mm-dd",
					editRenderer: {
						type: "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat: "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength: 8,
						onlyNumeric: true, // 숫자만
						validator: function (oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							if (newValue == "") {
								// 날짜 지울 시 검사X
								return;
							}
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver: true
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${page.fnc.F00768_001}" == "Y") {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "회사명",
					dataField: "cmp_name",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 30,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "80",
					minWidth : "70",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${page.fnc.F00768_001}" == "Y") {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "수행업무",
					dataField: "job_text",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 30,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "150",
					minWidth : "140",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${page.fnc.F00768_001}" == "Y") {
							return "aui-editable"
						}
						return "aui-left";
					}
				},
				{
					headerText: "직급",
					dataField: "career_grade_name",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 30,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "80",
					minWidth : "70",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${page.fnc.F00768_001}" == "Y") {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "비고",
					dataField: "career_remark",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 50,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "130",
					minWidth : "120",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ("${page.fnc.F00768_001}" == "Y") {
							return "aui-editable"
						}
						return "aui-left";
					}
				},
				{
					headerText: "삭제",
					dataField: "removeBtn",
					width : "80",
					minWidth : "70",
					renderer: {
						type: "ButtonRenderer",
						onClick: function (event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridCareer, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridCareer, {career_use_yn : "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridCareer, "selectedIndex");
								AUIGrid.updateRow(auiGridCareer, {career_use_yn : "Y"}, event.rowIndex);
							}
						}
					},
					labelFunction: function (rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style: "aui-center",
					editable: false
				},
				{
					headerText: "경력사항 순번",
					dataField: "career_seq_no",
					visible: false
				},
				{
					headerText: "사용여부",
					dataField: "career_use_yn",
					visible: false
				},
				{
					headerText : "CMD",
					dataField: "career_cmd",
					visible: false
				}
			];

			auiGridCareer = AUIGrid.create("#auiGridCareer", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCareer, careerListJson);
			$("#auiGridCareer").resize();
		}

		// 자격사항 그리드 생성
		function createAUIGridLicense() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				showStateColumn: true,
				editable: true
			};
			if(!authEditLicense) {
				gridPros.editable = false;
			}

			var columnLayout = [
				{
					headerText: "일자",
					dataField: "license_dt",
					dataType: "date",
					width : "80",
					minWidth : "70",
					dataInputString: "yyyymmdd",
					formatString: "yyyy-mm-dd",
					editRenderer: {
						type: "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat: "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar: false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength: 8,
						onlyNumeric: true, // 숫자만
						validator: function (oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							if (newValue != "") {
								return fnCheckDate(oldValue, newValue, rowItem);
							}

						},
						showEditorBtnOver: true
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (authEditLicense) {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "자격증명",
					dataField: "license_kind",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 10,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "80",
					minWidth : "70",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (authEditLicense) {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "내용",
					dataField: "content",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 50,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "200",
					minWidth : "190",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (authEditLicense) {
							return "aui-editable"
						}
						return "aui-left";
					}
				},
				{
					headerText: "자격근거(기관)",
					dataField: "license_biz_name",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 100,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "150",
					minWidth : "140",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (authEditLicense) {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "자격번호",
					dataField: "license_no",
					editRenderer: {
						type: "InputEditRenderer",
						maxlength: 100,
						// 에디팅 유효성 검사
						validator: AUIGrid.commonValidator
					},
					width : "150",
					minWidth : "140",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (authEditLicense) {
							return "aui-editable"
						}
						return "aui-center";
					}
				},
				{
					headerText: "자격증",
					dataField: "origin_file_name",
					width : "100",
					minWidth : "90",
					editable: false,
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
						if(item.license_file_seq == 0) {
							if (!authEditLicense) {
								return ""
							}
							return '<button type="button" class="btn btn-default" style="width: 90%" onclick="javascript:goUploadImg(' + rowIndex + ');">이미지등록</button>';
						} else {
							var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnPreview(' + item.license_file_seq + ');">' + value + '</span>' + '</div>';
							return template;
						}
					}
				},
				{
					headerText: "삭제",
					dataField: "removeBtn",
					width : "80",
					minWidth : "70",
					renderer: {
						type: "ButtonRenderer",
						onClick: function (event) {
							if (!authEditLicense) {
								alert("본인 및 관리부만 삭제 가능합니다.");
								return;
							}

							var isRemoved = AUIGrid.isRemovedById(auiGridLicense, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridLicense, {license_use_yn : "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridLicense, "selectedIndex");
								AUIGrid.updateRow(auiGridLicense, {license_use_yn : "Y"}, event.rowIndex);
							}
						}
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style: "aui-center",
					editable: false
				},
				{
					headerText: "자격사항 순번",
					dataField: "license_seq_no",
					visible: false
				},
				{
					headerText: "사용여부",
					dataField: "license_use_yn",
					visible: false
				},
				{
					headerText : "CMD",
					dataField: "license_cmd",
					visible: false
				},
				{
					headerText: "자격증이미지",
					dataField: "license_file_seq",
					visible: false
				}
			];

			auiGridLicense = AUIGrid.create("#auiGridLicense", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLicense, memLicListJson);
			if (!authEditLicense) {
				AUIGrid.hideColumnByDataField(auiGridLicense, ["removeBtn"]);
			}
			$("#auiGridLicense").resize();
		}

		//팝업 닫기
		function fnClose() {
			top.window.close();
		}

		// 퇴사자 업무 이관 팝업 - 김경빈
		function goRetireYiguan() {
			var param = {
				s_mem_no : $M.getValue("mem_no")
			}
			openRetireYiguanPanel('setRetireYiguanPanel', $M.toGetParam(param));
		}

		// 퇴사자 업무 이관 데이터 콜백 - 김경빈
		function setRetireYiguanPanel(data) {
			$M.setValue("misu_mem_name", data.misu_mem_name);
			$M.setValue("misu_mem_no", data.misu_mem_no);
			$M.setValue("todo_mem_name", data.todo_mem_name);
			$M.setValue("todo_mem_no", data.todo_mem_no);
		}

		// 부서 or 직책 변경시 부서권한 세팅
		function fnSetOrgAuth() {
			var param = {
				org_code: $M.getValue("org_code"),
				grade_cd: $M.getValue("grade_cd")
			};
			$M.goNextPageAjax("/orgAuth",  $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							$M.setValue("org_auth_cd", result.auth_org_code);
						}
					}
			);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="mem_no" name="mem_no" value="${bean.mem_no}"/>
	<input type="hidden" id="origin_resi_no" name="origin_resi_no" value="${bean.resi_no}">
	<input type="hidden" id="origin_hp_no" name="origin_hp_no" value="${fn:replace(bean.hp_no, '-', '')}">
	<input type="hidden" id="origin_web_id" name="origin_web_id" value="${bean.web_id}">
	<input type="hidden" id="origin_email" name="origin_email" value="${bean.web_id}">

	<input type="hidden" id="resi_no" name="resi_no" value="">
	<input type="hidden" id="resi_no_show_yn" name="resi_no_show_yn" value="N">
	<input type="hidden" id="lastChk_hp_no" value="${fn:replace(bean.hp_no, '-', '')}" name="lastChk_hp_no">
	<input type="hidden" id="lastChk_resi_no" value="${bean.resi_no}" name="lastChk_resi_no">
	<input type="hidden" id="lastchk_web_id" value="${bean.web_id}" name="lastchk_web_id">
	<input type="hidden" id="lastchk_email" value="${bean.email}" name="lastchk_email">
	<input type="hidden" id="web_id_chk" name="web_id_chk" value="Y">
	<input type="hidden" id="hp_no_chk" name="hp_no_chk" value="Y">
	<input type="hidden" id="resi_no_chk" name="resi_no_chk" value="Y">
	<input type="hidden" id="pic_file_seq" name="pic_file_seq" value="${bean.pic_file_seq}">
	<input type="hidden" name="upload_type" id="upload_type" value="${inputParam.upload_type }"/>

	<input type="hidden" id="secure_mem_no" name="secure_mem_no" value="${SecureUser.mem_no}" />
	<input type="hidden" id="secure_org_code" name="secure_org_code" value="${SecureUser.org_code}" />
	<input type="hidden" id="license_row_index" name="license_row_index" />
	<input type="hidden" id="misu_flag" name="misu_flag" value="${misuFlag}"/>
	<input type="hidden" id="todo_flag" name="todo_flag" value="${todoFlag}"/>

	<!-- 크롬 비번 자동완성 방지를 위한 input -->
	<input type="password" style="display: block; width:0px; height:0px; border: 0;">
	<input type="text" style="display: block; width:0px; height:0px; border: 0;" name="__id">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<div class="content-wrap" style="padding:0px;">
			<!-- 폼테이블 -->
			<div>
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="200px">
						<col width="100px">
						<col width="140px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th rowspan="5" class="text-center">
							<div class="mb20">
								프로필 사진
							</div>
							<div class="form-row inline-pd">
								<div class="col-12 ">
									<button type="button" id="fileAddBtn" class="btn btn-primary-gra" onclick="javascript:goUploadImg()" style="width: 100%;">사진 업로드</button>
								</div>
								<div id="fileDiv">
								</div>
							</div>
						</th>
						<td rowspan="5" class="text-center">
							<div class="profilephoto-item" onmouseover="javascript:fnDelBtnShow();" onmouseout="javascript:fnDelBtnHide();">
								<img id="profileImage" src="/file/${bean.pic_file_seq}" alt="프로필 사진" class="icon-profilephoto" style="width:150px;"/>
								<div class="profilephoto-delete" style="display:none;">
									<button type="button" id="fileRemoveBtn" class="btn btn-icon-md text-light"><i class="material-iconsclose font-16"></i></button>
								</div>
							</div>
						</td>
						<th class="text-right essential-item">직원명(한글)</th>
						<td colspan="3">
							<input type="text" class="form-control essential-bg width120px" style="display: inline-block;" value="${bean.kor_name}" id="kor_name" name="kor_name" datatype="string" required="required" alt="직원명(한글)" maxlength="15">
							<span style="display: inline-block;">사번 : ${bean.emp_id }</span>
						</td>
						<th class="text-right">직원명(영문)</th>
						<td colspan="3">
							<input type="text" class="form-control width120px" value="${bean.eng_name}" id="eng_name" name="eng_name" alt="직원명(영문)">
						</td>
						<th class="text-right essential-item">아이디</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width120px">
									<input type="text" class="form-control essential-bg" value="${bean.web_id}" id="web_id" name="web_id" required="required" alt="아이디" minlength="2" maxlength="30">
								</div>
								<div class="col width60px">
									<button type="button" id="btn_web_id_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goWebIdCheck();" disabled="disabled">중복확인</button>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">주민등록번호</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width70px">
									<input type="text" id="resi_no1" name="resi_no1" class="form-control" minlength="6" maxlength="6"
										   value="${fn:substring(bean.resi_no, 0, 6)}" datatype="int" onkeyup="if(this.value.length == 6) main_form.resi_no2.focus();" alt="주민번호 앞자리">
								</div>
								<div class="col width16px text-center">-</div>
								<div class="col width70px">
									<input type="password" id="resi_no2" name="resi_no2" class="form-control" minlength="7" maxlength="7" value="${fn:substring(bean.resi_no, 6, 13)}" datatype="int" alt="주민번호 뒷자리">
								</div>

								<div class="col width60px">
									<button type="button" id="btn_resi_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goResiNoCheck();" disabled="disabled">중복확인</button>
								</div>
								<div class="col width60px">
									<!-- 관리부만 사용가능 -->
									<c:if test="${inputParam.login_org_code eq '2000'}">
										<button type="button" id="btn_show_resi_no" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:fnShowResiNo();" >보기</button>
									</c:if>
								</div>
							</div>
						</td>
						<th class="text-right">생년월일</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width120px">
									<div class="input-group">
										<input type="text" id="birth_dt" name="birth_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 calDate" value="${bean.birth_dt}" alt="생년월일">
									</div>
								</div>
								<div class="col width120px pl5">
									<div class="form-check form-check-inline" style="margin-right: 0px;">
										<input class="form-check-input" type="radio" name="solar_cal_yn" value="Y" ${bean.solar_cal_yn == 'Y'? 'checked="checked"' : ''}>
										<label class="form-check-label">양력</label>
									</div>
									<div class="form-check form-check-inline" style="margin-right: 0px;">
										<input class="form-check-input" type="radio" name="solar_cal_yn" value="N" ${bean.solar_cal_yn == 'N'? 'checked="checked"' : ''}>
										<label class="form-check-label">음력</label>
									</div>
								</div>
							</div>
						</td>
						<th class="text-right essential-item">입사일자</th>
						<td colspan="3">
							<div class="input-group width120px">
								<input type="text" id="ipsa_dt" name="ipsa_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 essential-bg calDate" value="${bean.ipsa_dt}" required="required" alt="입사일자">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">핸드폰</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width140px">
									<input type="text" class="form-control essential-bg" id="hp_no" name="hp_no" minlength="10" maxlength="11"
										   value="${fn:replace(bean.hp_no, '-', '')}" format="phone" placeholder="숫자만 입력" required="required" alt="핸드폰">
								</div>
								<div class="col width60px">
									<button type="button" id="btn_hp_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goHpNoCheck();" disabled="disabled">중복확인</button>
								</div>
							</div>
						</td>
						<th class="text-right essential-item">비상연락처</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-6">
									<input type="text" class="form-control essential-bg" id="emergency_contact_relation" name="emergency_contact_relation" placeholder="비상연락처관계"
										   value="${bean.emergency_contact_relation}" datatype="string" required="required" alt="비상연락처관계">
								</div>
								<div class="col-6">
									<input type="text" class="form-control essential-bg" id="emergency_contact_phone_no" name="emergency_contact_phone_no" placeholder="-없이 숫자만"
										   value="${bean.emergency_contact_phone_no}" minlength="9" maxlength="20" required="required" alt="비상연락처">
								</div>
							</div>
						</td>
						<th class="text-right">이메일</th>
						<td colspan="3">
							<input type="text" class="form-control width180px" value="${bean.email}" id="email" name="email" format="email" readonly="readonly">
						</td>
					</tr>
					<tr>
						<th class="text-right">직원구분</th>
						<td colspan="3">
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" name="mem_type_cd" value="01" ${bean.mem_type_cd == '01'? 'checked="checked"' : ''} disabled="disabled">
								<label class="form-check-label">직원</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" name="mem_type_cd" value="02" ${bean.mem_type_cd == '02'? 'checked="checked"' : ''} disabled="disabled">
								<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
								<%--<label class="form-check-label">대리점</label>--%>
								<label class="form-check-label">위탁판매점</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" name="mem_type_cd" value="03" ${bean.mem_type_cd == '03'? 'checked="checked"' : ''} disabled="disabled">
								<label class="form-check-label">일반</label>
							</div>
						</td>
						<th class="text-right">전화(사무실)</th>
						<td colspan="3">
							<input type="text" class="form-control width140px" value="${bean.office_tel_no}" id="office_tel_no" name="office_tel_no" minlength="9" maxlength="20" alt="전화(사무실)">
						</td>
						<th class="text-right">전화(팩스)</th>
						<td colspan="3">
							<input type="text" class="form-control width140px" value="${bean.office_fax_no}" id="office_fax_no" name="office_fax_no" minlength="9" maxlength="20" alt="전화(팩스)">
						</td>
					</tr>
					<tr>
						<th class="text-right">부서</th>
						<td colspan="3">
							<div>
								<input type="text" class="form-control width120px" id="org_name" name="org_name" required="required" alt="부서" value="${bean.org_name}" disabled="disabled"/>
								<input type="hidden" class="form-control" id="org_code" name="org_code" required="required" alt="부서코드" value="${bean.org_code}" disabled="disabled"/>
							</div>
						</td>
						<th class="text-right essential-item">부서권한</th>
						<td colspan="3">
							<select class="form-control" id="org_auth_cd" name="org_auth_cd" readonly="readonly" alt="부서권한">
								<option value=""></option>
								<c:forEach items="${menuOrgList}" var="item">
									<option value="${item.org_code}" ${item.org_code == bean.org_auth_cd ? 'selected' : '' }>${item.path_org_name}</option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">업무권한</th>
						<td colspan="3">
							<input class="form-control" style="width:99%" type="text" id="job_auth_cd" name="job_auth_cd" alt="업무권한"
								   easyui="combogrid" easyuiname="jobAuthList" panelwidth="400" multi="Y" idfield="code_value" textfield="code_name"/>
						</td>
					</tr>
					<tr>
						<th class="text-right">직급</th>
						<td class="pr">
							<div class="form-row inline-pd pr">
								<div class="col-12">
<%--									<select class="form-control" id="job_select_box" name="job_select_box" alt="직급구분" ${bean.work_status_cd != "04" ? 'disabled' : '' }>--%>
									<%-- 2023/02/16 재호 : 직급 변경 요청으로 disabled 해제 --%>
									<select class="form-control" id="job_select_box" name="job_select_box" alt="직급구분" ${page.fnc.F00768_001 == 'Y' ? '' : 'disabled'} >
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['JOB']}" var="item">
											<option value="${item.code_value}" ${item.code_value == bean.job_cd ? 'selected' : '' }>${item.code_name}</option>
										</c:forEach>
									</select>
<%--									<input type="text" class="form-control width120px" id="grade_name" name="grade_name" alt="직급구분" value="${bean.grade_name}" disabled="disabled">--%>
									<input type="hidden" class="form-control" id="job_cd" name="job_cd" required="required" alt="직급코드" value="${bean.job_cd}">
								</div>
							</div>
						</td>
						<th class="text-right">직책</th>
						<td colspan="3">
							<div style="display: flex">
								<select class="form-control" id="grade_select_box" name="grade_select_box" alt="직책구분" ${bean.work_status_cd != "04" ? 'disabled' : '' }>
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['GRADE']}" var="item">
										<option value="${item.code_value}" ${item.code_value == bean.grade_cd ? 'selected' : '' }>${item.code_name}</option>
									</c:forEach>
								</select>
								<c:if test="${page.fnc.F00768_001 eq 'Y'}">
									<button type="button" id="btn_grade_job_save" class="btn btn-primary-gra ml5" onclick="javascript:handlerGradeJobSaveClick();">직급/직책 저장</button>
								</c:if>
							</div>
<%--							<input type="text" class="form-control width120px" id="job_name" name="job_name" alt="직책구분" value="${bean.job_name}" disabled="disabled">--%>
							<input type="hidden" class="form-control" id="grade_cd" name="grade_cd" required="required" alt="직책구분코드" value="${bean.grade_cd}">
						</td>
						<th rowspan="3" class="text-right essential-item">자택주소</th>
						<td colspan="7" rowspan="3">
							<div class="form-row inline-pd mb7 widthfix">
								<div class="col width100px">
									<input type="text" class="form-control essential-bg" value="${bean.home_post_no}" id="home_post_no" name="home_post_no" readonly="readonly" required="required" alt="자택주소">
								</div>
								<div class="col width60px">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnSetAddress');">주소찾기</button>
								</div>
							</div>
							<div class="form-row inline-pd mb7">
								<div class="col-12">
									<input type="text" class="form-control essential-bg" value="${bean.home_addr1}" id="home_addr1" name="home_addr1" readonly="readonly" required="required" alt="자택주소">
								</div>
							</div>
							<div class="form-row inline-pd">
								<div class="col-12">
									<input type="text" class="form-control essential-bg" value="${bean.home_addr2}" id="home_addr2" name="home_addr2">
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">재직구분</th>
						<td>
							<select class="form-control essential-bg" id="work_status_cd" name="work_status_cd" required="required" alt="재직구분">
								<option value="">- 선택 -</option>
								<c:forEach items="${codeMap['WORK_STATUS']}" var="item">
									<option value="${item.code_value}" ${item.code_value == bean.work_status_cd ? 'selected' : '' }>${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">퇴직일</th>
						<td colspan="3">
							<input type="text" id="retire_dt" name="retire_dt" dateFormat="yyyy-MM-dd" class="form-control width120px" value="${bean.retire_dt}" readonly="readonly" alt="퇴직일">
						</td>
					</tr>
					<tr>
						<th class="text-right">퇴직 시 회사의견</th>
						<td colspan="5">
							<input type="text" class="form-control" value="${bean.cert_company_opinion}" id="cert_company_opinion" name="cert_company_opinion" readonly="readonly" alt="퇴직 시 회사의견">
						</td>
					</tr>
					<tr>
						<th class="text-right">급여계좌</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-4">
									<input type="text" class="form-control" id="salary_bank_name" name="salary_bank_name" placeholder="은행명" alt="급여은행명" value="${bean.salary_bank_name}">
								</div>
								<div class="col-8">
									<input type="text" class="form-control" id="salary_account_no" name="salary_account_no" placeholder="계좌번호" alt="급여계좌번호" value="${bean.salary_account_no}">
								</div>
							</div>
						</td>
						<th class="text-right">휴가일수</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" id="issue_cnt" name="issue_cnt" class="form-control text-center" readonly="readonly" value="${bean.issue_cnt}">
								</div>
								<div class="col width16px">일</div>
							</div>
						</td>
						<th class="text-right">휴가사용일수</th>
						<td >
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" id="used_cnt" name="used_cnt" class="form-control text-center" readonly="readonly" value="${bean.used_cnt}">
								</div>
								<div class="col width16px">일</div>
							</div>
						</td>
						<th class="text-right">휴가잔여일수</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width60px">
									<input type="text" id="unused_cnt" name="unused_cnt" class="form-control text-center" readonly="readonly" value="${bean.unused_cnt}">
								</div>
								<div class="col width16px">일</div>
							</div>
						</td>
						<th class="text-right">수습해지일자</th>
						<td colspan="3">
							<div class="input-group width120px">
								<input type="text" id="regular_st_dt" name="regular_st_dt" dateFormat="yyyy-MM-dd" class="form-control" value="${bean.regular_st_dt}" disabled="disabled" alt="수습해지일자">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">키</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<input type="text" id="bdoy_height" name="bdoy_height" class="form-control text-center" value="${bean.bdoy_height}">
								</div>
								<div class="col-auto">Cm</div>
							</div>
						</td>
						<th class="text-right">정비화사이즈</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<input type="text" id="repair_shose_size" name="repair_shose_size" class="form-control text-center" value="${bean.repair_shose_size}">
								</div>
								<div class="col-auto">Cm</div>
							</div>
						</td>
						<th class="text-right">정비복사이즈</th>
						<td>
							<select class="form-control width80px" id="repair_clothes_cd" name="repair_clothes_cd">
								<option value="">- 선택 -</option>
								<c:forEach items="${codeMap['REPAIR_CLOTHES']}" var="item">
									<option value="${item.code_value}" ${item.code_value == bean.repair_clothes_cd ? 'selected' : '' }>${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">근무복사이즈</th>
						<td>
							<select class="form-control width80px" id="work_clothes_cd" name="work_clothes_cd">
								<option value="">- 선택 -</option>
								<c:forEach items="${codeMap['WORK_CLOTHES']}" var="item">
									<option value="${item.code_value}" ${item.code_value == bean.work_clothes_cd ? 'selected' : '' }>${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">수습적용여부</th>
						<td colspan="3">
							<div class="col-9">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="temp_apply_yn1" name="temp_apply_yn" value="Y" ${bean.temp_apply_yn == "Y" ? 'checked' : '' }/>
									<label class="form-check-label" for="temp_apply_yn1">Y</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="temp_apply_yn2" name="temp_apply_yn" value="N" ${bean.temp_apply_yn == "N" ? 'checked' : '' }/>
									<label class="form-check-label" for="temp_apply_yn2">N</label>
								</div>
							</div>
						</td>
					</tr>
					<tr id="yiguan_table">
						<th id="misu_th" class="text-right">이관 미수담당자</th>
						<td id="misu_td">
							<div class="form-row inline-pd widthfix">
								<div class="col">
									<input type="text" class="form-control width120px" id="misu_mem_name" name="misu_mem_name" alt="이관 미수담당자" readonly="readonly">
									<input type="hidden" class="form-control" id="misu_mem_no" name="misu_mem_no" alt="이관 미수담당자">
								</div>
							</div>
						</td>
						<th id="todo_th" class="text-right">이관 미결담당자</th>
						<td id="todo_td" colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col">
									<input type="text" class="form-control width120px" id="todo_mem_name" name="todo_mem_name" alt="이관 미결담당자" readonly="readonly">
									<input type="hidden" class="form-control" id="todo_mem_no" name="todo_mem_no" alt="이관 미결담당자">
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<div class="row mt10">
				<div class="col-6">
					<!-- 발령사항 -->
					<div class="title-wrap mt10">
						<h4>발령사항</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGridMove" style="margin-top: 5px; height: 158px;"></div>
					<!-- /발령사항 -->
					<!-- 자격사항 -->
					<div class="title-wrap mt10">
						<h4>경력사항</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGridCareer" style="margin-top: 5px; height: 158px;"></div>
					<!-- /자격사항 -->
				</div>
				<div class="col-6">
					<div class="title-wrap mt10">
						<h4>지급품목</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGridAssetPayment" style="margin-top: 5px; height: 158px;"></div>
					<div class="title-wrap mt10">
						<h4>자격사항</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGridLicense" style="margin-top: 5px; height: 158px;"></div>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>
