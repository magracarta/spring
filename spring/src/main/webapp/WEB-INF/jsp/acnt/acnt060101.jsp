<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > 직원신규등록 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-13 11:27:57
-- 2022-12-19 jsk : erp3-2차 권한관리 수정
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var defaultImg = "/static/img/icon-user.png";
		var workStatusList = JSON.parse('${codeMapJsonObj['WORK_STATUS']}');
		var auiGridMove; // 발령사항
		var auiGridAssetPayment; // 지급품목
		var auiGridCareer; // 경력사항
		var auiGridLicense; // 자격사항
		$(document).ready(function () {
			$("#kor_name").focus();

			fnInit();

			// AUIGrid 생성
			createAUIGridMove(); // 발령사항 그리드 생성
			createAUIGridauiGridAssetPayment(); // 지급품목 그리드 생성
			createAUIGridCareer(); // 경력사항 그리드 생성
			createAUIGridLicense(); // 자격사항 그리드 생성

			$("#retireField").children("button").addClass("btn-cancel");
			$("#retireField").children("button").attr("disabled", true);

			//퇴직여부 확인
			$("#work_status_cd").change(function () {
				if ($M.getValue("work_status_cd") == "04") {
					fnRetireYn(true);
				} else {
					fnRetireYn(false);
				}
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
				if ($M.getValue("lastchk_web_id") == this.value) {
					$M.setValue("web_id_chk", "Y");
					$('#btn_web_id_chk').prop('disabled', true);
				} else {
					$M.setValue("web_id_chk", "N");
					$('#btn_web_id_chk').prop('disabled', false);
				}
			});

			// eamil 변경 시 webid 중복체크 다시 실행
			$("#email").on("propertychange change keyup paste input", function () {
				var email = $M.nvl($M.getValue("email"), "");
				if ($M.getValue("lastchk_email") == this.value) {
					$M.setValue("web_id_chk", "Y");
					$M.setValue("lastchk_email", this.value);
					$("#btn_web_id_chk").prop("disabled", true);
				} else {
					$M.setValue("web_id_chk", "N");
					$("#btn_web_id_chk").prop("disabled", false);
				}
			});

			// 핸드폰번호 중복체크 완료 후 번호 변경 시 중복체크 다시 실행
			$("#hp_no").on("propertychange change keyup paste input", function () {
				if ($M.getValue("lastChk_hp_no") == this.value) {
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

				// 주민등록번호 입력 안할 시 중복체크X
				if (resi_no == "") {
					$M.setValue("resi_no_chk", "Y");
					$("#btn_resi_no_chk").prop("disabled", true);
					return;
				}

				if ($M.getValue("lastChk_resi_no") == resi_no) {
					$M.setValue("resi_no_chk", "Y");
					$("#btn_resi_no_chk").prop("disabled", true);
				} else {
					$M.setValue("resi_no_chk", "N");
					$("#btn_resi_no_chk").prop("disabled", false);
				}
			});

			// 부서, 직책 변경 이벤트
			$("#grade_cd").change(function () {
				fnSetOrgAuth();
			});
		});

		function fnInit() {
			var secureOrgCode = "${SecureUser.org_code}";
			var secureMemNo = "${SecureUser.mem_no}";

			if(("${page.fnc.F00767_001}" == "Y") == false) {
				$("#_fnAdd").prop("disabled", true);
			}
		}

		// 재직구분 선택 시 이벤트
		function fnRetireYn(flag) {
			if (flag) {
				$("#retire_dt").attr("readonly", false);						// 퇴직일 입력가능
				$("#retireField").children("button").attr('disabled', false);	// 퇴직일 달력 사용가능
				$("#retire_dt").attr("required", true);							// 퇴직일 필수
				$("#cert_company_opinion").attr("readonly", false);				// 퇴직 시 회사의견 입력가능
			} else {
				$("#retire_dt").attr("readonly", true);							// 퇴직일 입력불가
				$("#retireField").children("button").attr('disabled', true);	// 퇴직일 달력 사용불가
				$("#retire_dt").attr("required", false);						// 퇴직일 필수X
				$("#cert_company_opinion").attr("readonly", true);				// 퇴직 시 회사의견 입력불가

				$M.setValue("retire_dt", "");									// 퇴직일 초기화
				$M.setValue("cert_company_opinion", "");						// 퇴직 시 회사의견 초기화
			}
		}

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
							;
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
		function goUploadImg() {
			var param = {
				upload_type: "MEM",
				file_type: "img",
				max_size: 1024,
				max_height: 200,
				max_width: 200,
			};
			openFileUploadPanel("fnSetImage", $M.toGetParam(param));
		}

		// 파일업로드 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result !== null && result.file_seq !== null) {
				$M.setValue("pic_file_seq", result.file_seq);
				$('#profileImage').attr("src", "/file/" + result.file_seq + '').width(188);
			}
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

			$M.goNextPageAjax(this_page + "/resiNoCheck", $M.toGetParam(param), {method: "post"},
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

		// 저장
		function goSave() {
			var sResi_No = $M.getValue("resi_no1") + $M.getValue("resi_no2");
			$M.setValue("resi_no", sResi_No);

			// 부서권한 필수체크
			// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
			if ($M.nvl($M.getValue("org_code"), "") != "") {
				if ($M.nvl($M.getValue("grade_cd"), "") == "") {
					alert("직책은 필수입력입니다.");
					return;
				}

				if ($M.nvl($M.getValue("org_auth_cd"), "") == "") {
					alert("부서권한이 없습니다. 직책관리 메뉴에서 부서권한 설정 후 처리해주세요.");
					return;
				}

				if ($M.getValue("org_code") == "4100") {
					alert("부서를 다시 설정하세요. 건기위탁판매점은 위탁판매점 분류입니다.");
					return false;
				}
				if ($M.getValue("org_code") == "4500") {
					alert("부서를 다시 설정하세요. 농기위탁판매점은 위탁판매점 분류입니다.");
					return false;
				}
				if ($M.getValue("org_code") == "4900") {
					alert("부서를 다시 설정하세요. 특수위탁판매점은 위탁판매점 분류입니다.");
					return false;
				}
			}

			// validation check
			if ($M.validation(document.main_form) === false) {
				return;
			}

			var frm = $M.toValueForm(document.main_form);

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

			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridCareer];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							//사용자 목록 이동
							fnList();
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
			AUIGrid.setGridData(auiGridMove, []);
			$("#auiGridMove").resize();
		}

		// 지급품목 그리드 생성
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
					dataField: "asset_type_name",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "보관부서",
					dataField: "use_org_name",
					width : "80",
					minWidth : "70",
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
				{
					headerText: "상태",
					dataField: "asset_owner_name",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				}
			];

			auiGridAssetPayment = AUIGrid.create("#auiGridAssetPayment", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridAssetPayment, []);
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
			if($M.getValue("secure_org_code") != "2000") {
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
						if ($M.getValue("secure_org_code") == "2000") {
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
						if ($M.getValue("secure_org_code") == "2000") {
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
						if ($M.getValue("secure_org_code") == "2000") {
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
						if ($M.getValue("secure_org_code") == "2000") {
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
						if ($M.getValue("secure_org_code") == "2000") {
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
						if ($M.getValue("secure_org_code") == "2000") {
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
							if ($M.getValue("secure_org_code") != "2000") {
								alert("관리부만 삭제 가능합니다.");
								return;
							}

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
			AUIGrid.setGridData(auiGridCareer, []);
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

			// 관리부가 아니면 editable = false
			var secureMemNo = $M.getValue("secure_mem_no");
			var memNo = $M.getValue("mem_no");
			if(secureMemNo != memNo) {
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
							if (newValue == "") {
								// 날짜 지울 시 검사X
								return;
							}
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver: true
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(secureMemNo == memNo) {
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
						if(secureMemNo == memNo) {
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
						if(secureMemNo == memNo) {
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
						if(secureMemNo == memNo) {
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
						if(secureMemNo == memNo) {
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
							if(secureMemNo != memNo) {
								alert("본인만 삭제 가능합니다.");
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
					labelFunction: function (rowIndex, columnIndex, value,
											 headerText, item) {
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
			AUIGrid.setGridData(auiGridLicense, []);
			$("#auiGridLicense").resize();
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

		function fnList() {
			history.back();
		}

		function fnClose() {
			window.close();
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="resi_no" name="resi_no" value="">
	<input type="hidden" id="lastChk_hp_no" name="lastChk_hp_no" value="">
	<input type="hidden" id="lastChk_resi_no" name="lastChk_resi_no" value="">
	<input type="hidden" id="lastchk_web_id" name="lastchk_web_id" value="">
	<input type="hidden" id="web_id_chk" name="web_id_chk" value="N">
	<input type="hidden" id="hp_no_chk" name="hp_no_chk" value="N">
	<input type="hidden" id="resi_no_chk" name="resi_no_chk" value="N">
	<input type="hidden" id="pic_file_seq" name="pic_file_seq" value="0">
	<input type="hidden" name="upload_type" id="upload_type" value="${inputParam.upload_type}"/>

	<input type="hidden" id="secure_mem_no" name="secure_mem_no" value="${SecureUser.mem_no}" />
	<input type="hidden" id="secure_org_code" name="secure_org_code" value="${SecureUser.org_code}" />

	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
				<!-- /상세페이지 타이틀 -->
				<div class="contents">
					<!-- 폼테이블 -->
					<div>
						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="200px">
								<col width="100px">
								<col width="270px">
								<col width="80px">
								<col width="">
								<col width="80px">
								<col width="">
								<col width="80px">
								<col width="">
								<col width="80px">
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
										<img id="profileImage" src="/static/img/icon-user.png" alt="프로필 사진" class="icon-profilephoto" style="width:150px;"/>
										<div class="profilephoto-delete" style="display:none;">
											<button type="button" id="fileRemoveBtn" class="btn btn-icon-md text-light"><i class="material-iconsclose font-16"></i></button>
										</div>
									</div>
									<!-- 크롬 비번 자동완성 방지를 위한 input -->
									<input type="password" style="display: block; width:0px; height:0px; border: 0;">
									<input type="text" style="display: block; width:0px; height:0px; border: 0;" name="__id">
								</td>
								<th class="text-right essential-item">직원명(한글)</th>
								<td>
									<input type="text" class="form-control essential-bg width120px" id="kor_name" name="kor_name" datatype="string" required="required" alt="직원명(한글)" maxlength="15">
								</td>
								<th class="text-right">직원명(영문)</th>
								<td colspan="3">
									<input type="text" class="form-control width120px" id="eng_name" name="eng_name" datatype="string" alt="직원명(영문)">
								</td>
								<th class="text-right essential-item">아이디</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control essential-bg" id="web_id" name="web_id" required="required" alt="아이디" minlength="2" maxlength="30">
										</div>
										<div class="col width60px">
											<button type="button" id="btn_web_id_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goWebIdCheck();">중복확인</button>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">주민등록번호</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" id="resi_no1" name="resi_no1" class="form-control" minlength="6" maxlength="6" datatype="int" onkeyup="if(this.value.length == 6) main_form.resi_no2.focus();">
										</div>
										<div class="col width16px text-center">-</div>
										<div class="col width70px">
											<input type="password" id="resi_no2" name="resi_no2" class="form-control" minlength="7" maxlength="7" datatype="int" alt="주민번호 뒷자리">
										</div>

										<div class="col width60px">
											<button type="button" id="btn_resi_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goResiNoCheck();" disabled="disabled">중복확인</button>
										</div>
									</div>
								</td>
								<th class="text-right">생년월일</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<div class="input-group">
												<input type="text" id="birth_dt" name="birth_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 calDate" alt="생년월일">
											</div>
										</div>
										<div class="col width120px pl5">
											<div class="form-check form-check-inline" style="margin-right: 0px;">
												<input class="form-check-input" type="radio" name="solar_cal_yn" value="Y" checked="checked">
												<label class="form-check-label">양력</label>
											</div>
											<div class="form-check form-check-inline" style="margin-right: 0px;">
												<input class="form-check-input" type="radio" name="solar_cal_yn" value="N">
												<label class="form-check-label">음력</label>
											</div>
										</div>
									</div>
								</td>
								<th class="text-right essential-item">입사일자</th>
								<td colspan="3">
									<div class="input-group width120px">
										<input type="text" id="ipsa_dt" name="ipsa_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 essential-bg calDate" required="required" alt="입사일자">
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">핸드폰</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width110px">
											<input type="text" class="form-control essential-bg width120px" id="hp_no" name="hp_no" format="phone" minlength="10" maxlength="11" required="required" alt="핸드폰" placeholder="-없이 숫자만">
										</div>
										<div class="col width60px">
											<button type="button" id="btn_hp_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goHpNoCheck();">중복확인</button>
										</div>
									</div>
								</td>
								<th class="text-right essential-item">비상연락처</th>
								<td colspan="3">
									<div class="form-row inline-pd">
										<div class="col-6">
											<input type="text" class="form-control essential-bg" id="emergency_contact_relation" name="emergency_contact_relation" placeholder="비상연락처관계" datatype="string" required="required" alt="비상연락처관계">
										</div>
										<div class="col-6">
											<input type="text" class="form-control essential-bg" id="emergency_contact_phone_no" name="emergency_contact_phone_no" minlength="9" maxlength="20" required="required" alt="비상연락처">
										</div>
									</div>
								</td>
								<th class="text-right essential-item">이메일</th>
								<td colspan="3">
									<input type="text" class="form-control essential-bg width180px" id="email" name="email" format="email" required="required" alt="이메일">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">직원구분<br>(부서에 종속)</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="mem_type_cd" value="01" checked="checked" disabled="disabled">
										<label class="form-check-label">직원</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="mem_type_cd" value="02" disabled="disabled">
										<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
										<%--<label class="form-check-label">대리점</label>--%>
										<label class="form-check-label">위탁판매점</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="mem_type_cd" value="03" disabled="disabled">
										<label class="form-check-label">일반</label>
									</div>
								</td>
								<th class="text-right">전화(사무실)</th>
								<td colspan="3">
									<input type="text" class="form-control width140px" id="office_tel_no" name="office_tel_no" minlength="9" maxlength="20" alt="전화(사무실)">
								</td>
								<th class="text-right">전화(팩스)</th>
								<td colspan="3">
									<input type="text" class="form-control width140px" id="office_fax_no" name="office_fax_no" minlength="9" maxlength="20" alt="전화(팩스)">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">부서</th>
								<td>
									<div>
										<input type="text" class="form-control essential-bg" style="width: 99%;" id="org_code" name="org_code" required="required" alt="부서"
											   easyui="combogrid" easyuiname="orgAllDepthList" panelwidth="350" textfield="path_org_name" multi="N" idfield="org_code" change="javascript:fnSetOrgAuth();"/>
									</div>
								</td>
								<th class="text-right essential-item">부서권한</th>
								<td colspan="3">
									<select class="form-control" id="org_auth_cd" name="org_auth_cd" alt="부서권한" readonly="readonly" >
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
								<th class="text-right">재직구분</th>
								<td>
									<input type="text" class="form-control" id="work_status" name="work_status" alt="재직구분" value="재직" disabled="disabled">
									<input type="hidden" class="form-control" id="work_status_cd" name="work_status_cd" required="required" alt="재직구분코드" value="01">
								</td>
								<th class="text-right essential-item">직급</th>
								<td class="pr">
									<div class="form-row inline-pd pr">
										<div class="col-12">
											<select class="form-control essential-bg" id="job_cd" name="job_cd" required="required" alt="직급">
												<option value="">- 선택 -</option>
												<c:forEach items="${codeMap['JOB']}" var="item">
													<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th rowspan="3" class="text-right essential-item">자택주소</th>
								<td colspan="7" rowspan="3">
									<div class="form-row inline-pd mb7 widthfix">
										<div class="col width100px">
											<input type="text" class="form-control essential-bg" id="home_post_no" name="home_post_no" readonly="readonly" required="required" alt="자택주소">
										</div>
										<div class="col width60px">
											<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnSetAddress');">주소찾기</button>
										</div>
									</div>
									<div class="form-row inline-pd mb7">
										<div class="col-12">
											<input type="text" class="form-control essential-bg" id="home_addr1" name="home_addr1" readonly="readonly" required="required" alt="자택주소">
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control essential-bg" id="home_addr2" name="home_addr2">
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">퇴직일</th>
								<td>
									<input type="text" id="retire_dt" name="retire_dt" dateFormat="yyyy-MM-dd" class="form-control" readonly="readonly" alt="퇴직일">
								</td>
								<th class="text-right essential-item">직책</th>
								<td>
									<select class="form-control essential-bg" id="grade_cd" name="grade_cd" required="required" alt="직책" change="javascript:fnSetOrgAuth();">
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['GRADE']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<th class="text-right">퇴직 시 회사의견</th>
								<td colspan="3">
									<input type="text" class="form-control" id="cert_company_opinion" name="cert_company_opinion" readonly="readonly" alt="퇴직 시 회사의견">
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
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" id="issue_cnt" name="issue_cnt" class="form-control text-center" readonly="readonly" value="${bean.issue_cnt}">
										</div>
										<div class="col width16px">일</div>
									</div>
								</td>
								<th class="text-right">휴가사용일수</th>
								<td>
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
										<input type="text" id="regular_st_dt" name="regular_st_dt" dateFormat="yyyy-MM-dd" class="form-control" readonly="readonly" value="" alt="수습해지일자">
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
								<td>
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
											<input class="form-check-input" type="radio" id="temp_apply_yn1" name="temp_apply_yn" value="Y" checked/>
											<label class="form-check-label" for="temp_apply_yn1">Y</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="temp_apply_yn2" name="temp_apply_yn" value="N"/>
											<label class="form-check-label" for="temp_apply_yn2">N</label>
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
									</div>
								</div>
							</div>
							<div id="auiGridAssetPayment" style="margin-top: 5px; height: 158px;"></div>
							<div class="title-wrap mt10">
								<h4>자격사항</h4>
								<div class="btn-group">
									<div class="right">
									</div>
								</div>
							</div>
							<div id="auiGridLicense" style="margin-top: 5px; height: 158px;"></div>
						</div>
					</div>

					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
